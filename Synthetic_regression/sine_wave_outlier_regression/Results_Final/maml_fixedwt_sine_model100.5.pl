��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_fixed_weight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_fixed_weight.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2170595024592qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2170595022000qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2170595024400qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2170595021328q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2170595025072q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2170595024496q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2170595021328qX   2170595022000qX   2170595024400qX   2170595024496qX   2170595024592qX   2170595025072qe.(       ��-�H`?���!����CZ=c�A��%�>����H�>�
M��C�����/�=x��彟�t?�kj��>C�ڽ���=���=F��>��=?��;�ؽ�rZ��P2��˿�����-~�w%����y�����p����>���ȷ�����(       `�>��?d�L��k'�K(�"rs���~���U��s	����LI�{:V�7���6p�&s޿�6"=�s>�k�vS->U���@w����֦�<��=�����Ά>m�>>ޔ���IQ>T���o9��8;��W����>��?�Z#��u�>8��M�<`RC�@      j�4����ɂi>͏����ｫ챽0N�=��)�p�Q=
 �=��=iĽ� >)�>:�ս��?r��=`�8=���N> y�<����,-<��$�<�@¾�J	>I->��/��i>��=��=�Ge=����?�I����4��Kف�7�����L�w/^�#��%���S��rC0�����t��F�	�>7�T��F�2���ġ��������~�6n�;�>��.��Q �5��Ϧ���=N��;��#���.�s���|�5�ӽoо�?���;�i?hV>�2"�,?�����z���F���z���E��y>��1>�=��.�s��o�*> U�:*Q>�����ڨ���=v�N>m������>=}>SB��}�>�P�y�]> �=���=Q��=�mX����>E�;= V >y(�]��=v3d�'�>Ð��?���D=q�D?��T>؁�=<6����<�M�=���6���k۽
�ƽC>'*��\�=.-�=�ڶ��ܟ=��ýTO!� ���ճ�R#=�<<f�<�o�<"��=���=�!���Xe����d�e�Hta�1Z>���:Gͽ���.F���<uZ���]��v�)i�<�7����?��cO�D穿�#��N�Y��=�>��>�d�Wm�-�G����q�'n�Ci+�7-������>�e�K>��	��p�>�^!���=�h~>�׈�<b=6�Ҿo����5=�.�u��>Y8�qI�>و�Ʈs>9��>H�2?]���� X?�近^�>�d >ti�����)޽��=�ԓ�[�<W#�Lߟ=Sü A�<�h����=��l�Em�渓=@�f��@����K�>�=ȶv>n�f���i�ڑ~�Hս�%�=:�׽���rv�=ַ0>P�4�D��B�p�O�4z�=f㦻�b���`�=�RC��Ψ����X���_C�7lT� �-����>��=Ql��iW=�{���>eȠ>�覾(񊾈Y�>O������p����M>���-�X�H=�=t�{��������>����B?��_��I>�o�>54�>�$ѿ�������-26=q.�u̾� �
�?r��a.>�S���ټ ʼ$3�=å�q�Vu�=d�h�>Y�=�}���Q��5󊽺$)��;m��"�!p��7����4�k���F>7���"�����q	��M��Q��j�������U��&���c4�<#�=PD��Q\�+����k���s�뭽pؘ<:A��޾h���'R��c�!�ٽVd=�;�7����|�6d𽆜d�W���TE<3��l贿\�2�]�M�`�-����2�=Y����	L=�N?xၾ�n�>w~����*3�=����A����?�G�h�*���پ7����`M�Rc���������~���(=#�"��L>A%���o�l��ߏ�p7���k��f����I���A�`�����ټ��I����U=p���Q���1>B���P��=�T=�5�\��=���=N��J��=���=m��	 ��M���s�����\=�f4�O �����=:���'i��;Z� ��� Z�;�/�=>�:�i�>=2��=��q�ߢe=��)��)_�/��l������=ֽ9�+��<%��=�u���~��	�=�*�pß�l��@H�<@��!�*�D��<����;��+�̹<Rsy�ؔ��g���0�i=b=���K���M>+�=�������\∾�.ѽ��m���$���=�����6>�>�<�Rk��a�>���=�n�>�<q>�މ>}�!?5�?`)u=�>�PW=���;�1=����iF��ӊ=H�ѽ�XE>Hײ�����1Vc����?��/?�Ǿ�N=��W=m'��F��=�'���Z��E+=�y�B�Ѿ��q<;�G��.��I�>`�;���g�0�M�O����i�>y����2>�,���C�X��%����0����=r�X?��f�o��>E�7??T�=f4)?���0'����?��A��ۜ���ʿ:Z���?y��E�>�`��=8�=�=���;{ =�":=�P������'6>.82=���$Q��������{ȏ����������@���������s=�	���$��:�2m6>��;N�e>`ͳ<K����V���r};;�w�y>=��=	�=�c�=�95=�8�=/Zj="����=����zOϾXfR����/>h=ǭ뽥u>�4ϛ�ă����<�����8��I��R���$E���>V�����t�)>Q ����U@<Y���q �i��璄�qR��e��(!����W�@��~~�[Y �J?���Dg>G��<{R���OL=�`����4�ϟ�o��4q�����>�R���:���HY���l���=h�9?E�n�]|�_��>���Qç�XY>l�����B�7�0���>ͧ�>%J�>s���×���>"��>h��?�I�V>��>���롿��|��G8��a濨r!���>�u�=�[�=�r�����ϼP���~�= �2�FX��}�W>��� �E�Q�Q�_.��%H=tc���,<
k�!-<���;���*=p��?K8��m)�W��<�,�ƴ%�	w���6= ��;d�ҽ�����	�D��<�j�����c�d�d=���>���!>�S��ĵ[����;��S�������Ž���=�ٽ>Z�I��Ѿ[8��L��ޗ�"?Z5��[;�>�E�1���_3=o�>dc�?2����?�yſ�7=�_%���H�s,��*7�?�ژ�7A�I��=.ƾ�u����=o󽐎:<HL=�%�;�ې���w��o���(�=>���4�A��=�ᵽB<�
�R=7��Qȼ����3<gk�G�=o�Ͻ�*> ?C�T~�M�==x�;�?�Hw'���;6Ҽ�����=���'=B���/)y<JUA�����	��2jǼ��>�!?�v=l�i>_�þ�Y>��=A���6�ǽ��(G���m�j�M�hC"=�-����=�R*>��ɽ^?����>&�M>+i>Q�>�����?���==n����O��GI=C�L�,'�������>��|��;�=��P?+{����K��e�=D��<xd2=2�������=G��=�>��׾ڝ�=++���n���Ƚ6��=�g����˽[\�V�6���[=iM��25^�W�6��H?<N콼�=ce��v�� �;`�^�6nƿ�+���=T���I�8�7������ȿN��?]�?�M��7�>Qd}�k)
�$$,��{������Q�� n�� �@<�j�<V�ؾ
7$�&�-c���k��M�&�����#�W�������'������~V��3���+�a|�>�݅?��R���<?0Y�) �3�!>t�v�Ò�ra�?�J���0�N���	��L�V�y���߾���=��]�i���6�7�I������ >2��T�)�X�./�=iʾr���8z��m��
� �U������V�e�<?*�\�1�#�����>!��?��(����&�=�yԾ�?���:k�.Ѻ=YWJ�B4�>p��>���}�@?H�������?���B����^�b�9�m�ؽ� >�;=��;�{�����=*�=��R�_>sʋ��7�=@�	=�^���hօ<޳�췭��*ҼQ�Xq�<�V�<-����ǽq���< ֘<�
> 0 <E��� �~:�c��v�N��Z���>��	E>@���s@=�i]>Ū;�>�v�ֈ�=G4+=��p<�	���,>��P���=�"�h%@��q>6oZ��Dy�(o�-s+;�r]�=���{���cZ��G^��w���?��-��K�;��@�=2��=�H�<2D�<�1�=��H��C]<��h�=�N=4@��"3>�<�6ڥ��>����6��ia>`��:Re��`����G"��|������ �<�Y�1ˮ?:"T�ހA>��E?>_@����_XU�aտ�ǽ=S�<�ߵ���:��dT�xa�?f6�Z��>y����?}�??�+6���>h�?�޸��'K��>kSH�̈́��)q	�P6�z��=݌O����=�W��C�=��`�b,%�0�����<$'���8���=B�=���< ����2>��=�S*�<�U��A̽�=_(��ձ<kֽxE
=ۦL��Z��>y�����.р=�h3�Bd��@d�P:^�'��>�?W�%��w�>��>�M���%>��8�,Cƽ��>�q�>�N���>:�>���H��?��5?���>3����Ѿ��1<�?�!��\��>w�>3�w?��߾Pgj�~��}��>��1>`Ͷ��2<>i+鿤���`?!�A�>�K?�ǅ>0�y<�d~=�i��n��V����2L5���=�j��w	��ڷ�=5�-=!=��6=��
<>�(�m��>����4�>4��>n��؛����<�	>U�̾�;��A	��
�>��� �??��>v6j������
>�c?�ug�yȠ=��?d� k�r���	��0B>g��G��<������=��>0q���Q�>b4�=Ķ+>+�l<�ѣ>�ڕ=��6�y⥾��:=)��=F{��k	<Rp�=���Ť�=���>h�>��}>@�?��=����^>�Dh�7S>�\����!z�t*w�yg�>�X���U� �T;����|��Yi/�����R�h��E���׬�HnJ=^	�;�z�6"=��`6��k���$�b�Ļ�{=���<���j�ܽ�O`�o��J��=7����܏��厾VpQ�F,k��X���MU�
(>�E����;���=�a-=r�H���
���-=�Ϟ���l�Zo�=`$�>)S��l���'?�Mg���+�2�۾-�>^��;�=�p>���)�b�e'�����)ܾEz��kԼ�[��?%>.��@%��lE�JPa?���ǣ�?Ul���Ǧ�)���x�9ǈ�݊־�q����?«�O�?ۦ3���)?����&/a���>jB쾒c�00u��R=ڬv>9ss�%@E��.�<Z��=觉��/Y�P@5>��s�6lȽA�S��:>M�>�|߾M�<����K@����>��u;��:�[��>)�W�?�>�>Y�y[�<�5?�J?7z��.Aa>�O�?u��cٷ=��<dO�W՛>�<�=����2�*�Lw�=���>yʾBtP>���ЩY���f_>5�ƽ<�˽G���}���@�>"� ?%�����h�k��"P��1��{��>r˿�R$�x+>�С���>��^=s6�U��ݺ?���>��q�||?)g��ؓ�����<���:�D ��N��B�;H����y�状<@��< \s<R~��$���f�=tA&��QL��<T��e
=�,;���S�h���&8�=�I=h�ҽ�p<�I9��&�<_5=�|ƻj~�<G�0�dm�t"�<dk,=��2�s�m�*�F��D� �r�w���H�<�vu��l;�~:���V���>8!�<�SȾ��`�>���<���=��<m���Y�<�I��dp?���>e땾c�ſ�G%�"W�/�(=c�;���N����>���>�Sݾ��Z>b�#�uhT>F:�/�����V�����	���\�o5�>���f/�=�J��"{��߷�un;]��{�*������~�dB�Rf��Ԋ��G1���_*1�C�������d��Ks�v�=ȍн�_=uွ�R%�t���^�T��0T��4���n���9�|Wj��3=U�o����<n>�=�<v���㊀���2�0%e�V;>nn���kn�����ƽ�K>\�ؾh�T���=�<�=9$l�*�u�i�P>9-�q�����ٿ��n>/d>�޾N�=:�#>��%�%�b>��I��wʿO@}>� κ���>!>I�W������?`b�>^�R�ML���^v?߯� cm�p��� �������z������h���Ҡ���@M�`\۽�,i������ָ�3�I��J��5J3�3���> ��.�>�߻��o��I�I��z����?=�̾�F~?ŎۿЏ�ZG	��P1�H����T��B�ƽ���>a�>x��Q���YֿЂm>nX�=���~G�-�>�H���:�� E�;|�ܽh2>Fu�=�ؽ���=��� ��;1[�[x���'�=�Y�l��\@�=~��=� ��$=���������$�O=�=����w=��A=Z��D��=0<Y=>*�=��=UF/�����nw����<�g=���       ���(       	��E��>�!?�:-�w�̾Pb>��?�S�o�)?0r�����>� *>m�?^L�>X��>��ͼo�����> 9#���>�� >*��.z�=�h�<�?����2%=먽>k��<U��>��S��I�>=�������G�PuM�9; ��qw�]��P#ɽ(       ��>�H,��B>�Z@<Blp?���,����=�ͽ>�l�=wڽҸ�>(~�?�_��I0�B�N�\??<RoI�P�3=N +��
�?a?%|�?�N=�_�=�M�
�f=G?ǖ	�l�c?��<��??�Գ��,��])9+��;o�=�Ó�}�?���