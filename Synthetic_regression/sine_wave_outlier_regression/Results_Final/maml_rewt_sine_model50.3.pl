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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   1398710272480qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   1398710267872qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   1398710270272qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   1398710271040q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   1398710267680q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   1398710268736q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   1398710267680qX   1398710267872qX   1398710268736qX   1398710270272qX   1398710271040qX   1398710272480qe.(       ����qAv����>��\�G��WM��Q�ݻ�K,�!�=��ﾆ��<+�?��;?U�,��&�7�[D?��o=^�P>�G���S��@F��?��� �=	S��.���`�?�u9=�G�>᭩���1?���=\��>;�����,>�-�>̔�>k!<E:|=(       t���4�
&��U������=Z��	�`S��v������]B�>U0��}p���<>�U�O�¿RQ�ƽu=V��>#�">Ә�������g<�˿����G%����>�Q��z�7�@�(�]i�k���=���i���Y�>s	?'���>|#�>+��       �WD�@      ̵K>E�:=�猾2�s>�[῿>�>Oʄ��q>�6�@`>�����<>�;'�څ�>��?������:����>�����D<�A��WN���9>��=��V��x �>E�>Rp>�.��>, ��n2=��n>bl=V���o����ɮ?���C�bk���֏>�뷽8;���,�&�	���f=�C���z@��X����>�F����Q�m��k0�t�+����>��Y���A��F�����=f�:��x����M��l�ga>t�̽�����"��ʾH���[{m��k�����3=�h��f�P?�KJ�㔾�h���	{�NF��&��������h��Y���z��?>�X׾^�j?8�?�W�����wf��v���;L>ʚ�=S¿1�m���H�#�p���Pb�K�2?�qx� ? =O'm�5Yʽ����h�;oQ5���>��G�񏅽��?�Ͽ�M���\u<��>��<>x>R��Qq^��V�Ja�<�%����t���s���Մv�a[��'�P;9>b���l�m?l
B�!�/�E��={�=C�z�j�|<��;>d>�����.��=j�.>�� �/��am�<�=� Ǿ\��=`�=u s>~�H?�9��a`��;�.>̇ =UM���|�q��cգ��0���븽U&>�֏��s�=���=�?�_�	���gV	�����t>+���}n��>� �&�J�+?>c�4�{����ꔾ�S=Z��2�ٽ���=����s,���p�>$B���4���4��<Kj�?n<o��:*�3���A��Z;=����?� ���������=k��z������@�PZG��6��F>�8��q\����=�DN����=���5��s�<S2��2ּ"�|=
`g���޽ӭ��h5��s��"^�u{񽧢�k�p=�{�=�p$=`2<�Z@���ji=֣�=�<,~
�e�=���֪��ۍ�<Ǌ �����I���ֽ,e�:2���S�~j>�b�=�(�=���=��Q;��g=e��<�������<;��<��L�[x�n [=�Ә��i�<&�+=�7|=���q~�E��=�1�=>ɽ��ٽ��z={���N�k>�Y��k�z�'L������Z�x����A?Y���X齮pƾ��5=��8��s?2mF==����j��햞�R�J����β��m�=�w�~�K�U�>̑��Bv�?1�����ؽ�[Y��>��<нo��X.$��q?��ܾ�@&�'8����?Қ�\�}=���=��=���<z>�P-�<0��= U���/Ľ8��<&���
q]��]��`���<���e뮽�� ��ɽ�И������什V�v&��Q���Ѽv���=I��@h
=�1������>� ̽��!����=Kl���������̩i=��=�4���X�=ڐ0��K�����i��6�=C��=ME/=�G���靽�5?��D>�U	<����2����>�$r?�u����� �B>����f�)甽������?=�����˗���H�V3<������ֿ���>���=(�J>ŕ�>%?AOY���� RE����@8�r9�����U��@�C���.��E%<�S=/�������u1>�D�;z1����N���p�'�@�����O�Ľ�ۉ�g=Y�$���\���=C��<���}d�����N95��I=]�&��qP�U2��Bb����� � I�qL��IZ�c
�y�\�[��h���������\<v�+��a�����Wξ�3_?�G���F�<p��,ܾ1��> @w;�<�'Vƿ���=X1ľ��H�� �?��>�6{��.E�2Î�H#�,����>ʽ���x�۽A۽���'q>�&�?�K��h����ݽ�o��Uo���p�UX]�7��=���2z��Tb�����>�[���/�>�E�?�{��.m�SP9����>�ӿ�@�=A� ��.O<D���J�2=�ӵ�dG=PVF?��<��	��c���l�=Xtn9>mo[>��>��ھ8�>���vx�I�j�|�ל�<�]���/��n���h���
,�x.�=F������in���!>H<�;�~3��)w�GL*�sɂ�>
<�� ��`#� (��M�酾�׾�� ��6 ����t���'���!.彺m�=՗�=Mȣ��m&����F+���?"`$��u�>��?=��=Φپ���=3�w�;(M���>*[?��N�1q>��X�<g��'�n�(qo���=����U��坤>#���*�K<G�n��C�L�5>�� ��� ��>2�:��<��>	�<c���5 �>I�\=�!9�y!?�O*i�|�>$�?Oځ�uH=&����������<P�����<��>J��������ռ�=�<L�=�����~p=�l	���=�\̽�:j�+��=��=�8��pFD�C����X;A-3�4�%��1�=\�3�ߚͽ�y�^�>����=��h꺼�p��h��=Ǣ!�$'y=�`S��z����
X^>㽏��D6>���Tq�2�=@φ��Z˾��$�C���!?m�e�����Nm����kwa?�˺�5�+7��il�<#�ܾ��+=�p$��vv>�����>��y5����@�&��˼1i羠������C2�=A�$>�"�?�P�N�Ž��	>��9�!3&���#��
�&\%��mѼbT �I��=
F��1������h�����!���9=R�Y���Ͻ�yF=�`T=���=�n�g�w��.`<3�1��2V�ڡ ���=���t#2���%���ּ�.=��==�f����<�D�����S_�C� �Z���G=o�>������;�-��I��7]<��=~�;�����j�>�m�=-��=�����Va�W@ͽ�줽��,��ܨ=���l�< սFn=C�����<3����>+���F3��R�<δ�=G2T���F��h�:�[��;�ٓ+��佽� W����=�j��67�7�z��W==K��񅐽��p�2��=Q��	�"r���Ղ�S���>`N;��X>@ ��J��= .�=6��<^���p��p=%=��N��� �PE8=\�E<c�� ����� �=�ſ<�@Y�Dq��ז���|���b=s7�q�d>z=��_����L��Wջ���5�jE�=�'�=3�j:�
>���<ɉ�=b����_X��j==�u��l�>PsӼ�ɼ�f��M�f]1>_�½���+��B$�Ƒ�=������=�����<Z�	>Lᖻ�Y���R�\d9�s�?��6���=�� �	X�C�$? Δ?J�?#�f>�z���ʻ�5n��'<v��fǼ�Ӊ	�6N��?4��ھ��?��^�eJ�=0�^>w��o��>�K8�К��O�&��Dk��E�����=~�B�W�߽��W��=T��� ��>�an?t������>ju��d󑿟�f=�����#
��a����=�T�5ɼRK�V����5��V�='X��co�)
�����o�<��gg����=�~�9������sT���+���o?�����G�=���;�=8�4����L=�b�y{k�fH�>J�����5�|��Ӊ�_@=�P��Y���:��>���N3<��ܽ�0D�.���9>x0���������s�0�I��nl(��T>� >?7=�W�Bt���O�ލ��IWd�r�0��c�������};c7>ft=L�=��&e>H��>�(n��uξx�K�f�?�����Ր�p�ٽ�X�O��$E𽻺Q�:c�<n����M� 5��8&�<	4�>��Ю!�L���J��}Z��>�q���ٽb�/��%���;�z�1@=����;�=�W�=v�q�"a����=�qv<�l=�'F��W��H;ý��L�p9��߄�8m#>��
�<�`=+~/�+�	��5�=�L���>t��<�D�<𱾞���T�=[5�?_!,<Xa>�i����/�>%�?f]��v꓾���d1>dV��碞�"���Y�>�h>�Ó;CQ����#�j���7=ɸ=��ſe?;5=,�o�E?��>Ҡ�=���]����}�>6�N?��>X@����9>{��<b����7s�	���8W>�#�<�����/\�ԙ�=�%"��!*?@u��� ��� �=Ø�i8=��Y=lzƽ"?���>�m��5>�R�=8�>`���(>8�>�X��=�L=���? <�;j���]�r����R?��쌿��=�.�(��S��7N�x:���O�l1�%򒿄A�=��9���۽�Ͼ'����,?6��`愾���>T����u�dy]���Jp���C>�p�:�q���G=qab=����0�ս�@>�/��S�=�x�?�;����<&�M��l�<~n�=揂���H��/��Ց��=b����E��Hl�&tF=����4%=�Ta=����˽�
�+{�=��2�h�~=Sә����<���i�=��=a��iZ>��;�U�"�>�%�M�N]�����;L��0m�=�:���ǻ�Z缐U)>
$�=;-��s�?a'���0�=�@��9�>�Zj��~�>��½����)2�>]!�>�N����>�H!?�+#�޷�>����<��=#��>m~>��ؾs����c>8��<J�k�8;>�p=�X��Z�[>����� �>���>��F��?�_�>��(��d��B�=�7����>�.���v��MF��'=ח>����J��T�����e�[>f$>����^��/�?A⺿*�L�0]U��#>��$��G�@`��摛�����	����	t�����k��$�>P���=�D��<�=aJ?l�.���b>F���\����:�=	�?U�!>'�>��>�ޞ=��,�Ÿ�-I���xV>"���ȯ޾
���!��>ZRc?~u!�t����d��?��=0N־��>���>O0z>�2(�l����%?I��!V9>�Ȫ=������?Ƅν��6>��u=Q6�m�O>�G��箽V8��!
 =P�s���:)B>��N�cD�=`�d=���D*�໲�Wy]=�]���A���B� C��|����K�>���=������a>�]o;��s�O>HzL=Е;<��'�<~�=��ս�����?=X�&=D�D=�*�=L�i�sK���.�=��>k/; ��>�~�? ��>�  >����yM����>�a׽�>t>FS�B����FF>ؑ�k���Q�?���k'����>���9�5�>���>���=�
u>�:��?�N�<v}<���{>����� B=��> �=>>!�>S����|�<8�)���<��n>cO�	�=�\C�XB�%I���\����>��ܽ�7�=)�Q��;��@V���=�z>(��җ��cB>���>�P����<��b�V�[>./�� Xھg��V�A�������=�K�p*�"AĽ�N��J�M������>���=�����=�N?hU���Q�=BoY=�=���>r���X>}:�=ַ��ߠ�"Z6>�\>�z���q����͓+�A��=�`�>:<����=�g�>�>��Q>k">��>��;;&>�t��s�>�͜=/#7�'��=��>�?��Z=ե<
f��恿1	��[3�;=⽫P޾wm��`����@�f���F�L�����w��zw=;!<��h�J�=?��)��AH�.W��b�=vѿgK=>�!�|%h�{�[��ɽp?������?�ֈ��w��ZĀ�����3[�<�b��	.S�@�D?��+�I�-�l,оf�4�d@��궹>�����I�=��?3�;���-?��ÿ>�X>�Z�;������&�) � _�� %=(�D��c'������E�f8,?���#q�!E��9�S>��*�n_�>���E����/��@����
��U1�ԗ��u>�J��]���mǾz;���l>��?�Sξ(��e\���ܽ����(>9C�P�<�zҽ&���T��.Y۽���!Kͼ�� ����K�=؈�<��u=8��5���������<�ފ������S*�t�<J���F\�=7ٽh,d=���к)=�5�oXD�z.�=�	�_�P���<N���[�7���ʻ3�
~l���.�9|޽8]����!a�S�E=���!�G�K8��^*=ͼB>b��DE�yi�|��Ȋ����?ͽ�UH�����_U���eQ���^� � =tW��$���3	�5W���d�=jB;�Y� ����J��I�=s�4�(       �3>��=���4��=0pᾩN��{���d?����һ� ���}=닽�q������>f���	��=pܻ�K�	~u�炽S6�? ;[=�?�u��6L�x?�?�>S.�<P$տ��>��׿�{��H������&ܾ�)=���0^#�(       �¾�m�>_��;~�N��fS=�(�����T>p��1���>`�>�� ?��P>��=��%?m��>���D��4Ŋ=�y�>j�>�\O�|�q�4�?��,����
����?���m[F��9�>d�8����=�O9?���>��.�����)�hY���#�