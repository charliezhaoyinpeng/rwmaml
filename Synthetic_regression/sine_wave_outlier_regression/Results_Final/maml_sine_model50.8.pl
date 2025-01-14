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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   1552530027808qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   1551991976496qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   1551991976688qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   1551991982064q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   1551991976304q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   1551991979376q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   1551991976304qX   1551991976496qX   1551991976688qX   1551991979376qX   1551991982064qX   1552530027808qe.(       @�Ľk�=�f�>מ󾸽3�\�]6��!K�n@?�O�F�:���=�6��뚩>w@*�J�?Lý<���>HHx�"[����1�O-?�K�<I�{?��>'���y?��>+�ͼT��>�@���G�������Ӽ�ۣ<R,d�d��Vj�=w�ý�A��(       _������}*?����p�<���>��>����U*=b�w�ă?X�>Rx�>��<�v�=T{�CU<���3?����!!>S�=��Z�O
3>`?c! ?�6�=9]?+M	�(;��]�>��俏�F?w��jc<�굽(L>�:�;	]���:�!_;�@      �A=`���uW����<@������%��8����=��������`����=�2����<%2�SqV�Z�P�J�E�MC �� ��мciT��?���
y=C��C�=�7�=wo�N��"�=�>�_.��O�Ľ�pɽ�0�����^��=#l���,;`�\=�D�=%M������y7=�*��C��Nf�=6�Y�M���'��WT��J���M�H���ߪ<��ắ4��A�>��]�����¼��̽
�/<����h�R=15d�ҭ�=� >M#��
=@�N��C��z��	Y�f���2� b;�>��g=���?ܪ=���=����Jk@�^x�>��ѿ�.q��%��a����6?Zb�>˟o���K88>���J��W�=��Q@>+=�`����7>��>���}kD�7§>b78=[z< I���� �>��`�u�=���<�����-���½��h�-�}�49��X�ɽFZ�=���G��<:��>������X��32=çn��P�.�`>�g>z�_:�0� �W>�8�<c����I�<�R>Ǫc�<�ݽ6wk����=>�nU�km�?�.>���;�i����;�/��L(�|=��'�F(۾sv��HjY��R�����;�*�C���=��=Kb���B��i��=��5�����g=ڜ>�m>%i}���x�c��:iӗ��
�>3�`>���=2�ӽM����R=.d��9ƽ����Mf>�G�H_>\��=�w`=s�m>=V�����X�C�n�-�=־�n��g����*>2m�=����)~>ɿ�>31�>��T>[ �=�4�!5�>m=ｷ�?�ܼi���L�=ؑ���C˽�dE>\��E�i��<f>צ��\��?�t>-^����><u+=b��lS�@�%?Pǹ=ff�f!����>!ݽ"����"�=������T=�<�=nQ7>�����G���?K�(��'1����>�`������.�=H�پ��<�g�H?���<�(��=�羮S�>XV8��G�=�U뽾X�=�"�$��>`��=L>�f��M>��=;鱽���=����J�������LK�=;c=
U�=�����>9P��Zb�=s��W������꺼�O=��� e����3�~(��R������6a=j�༇C�t�<t7 �	�	�J?J��Y^=��<�|ڽ��!��,t;U7r�v��rX8�X����ڼzU�� �߼@yq=M�I��[�=��9�ʌ�;�r >��=��=Y1Կ޷=J�(?�{�?Tf�g<?z�;�]Z:�oD�>�־z��>F:e?mF�=�l��ᇶ��ѓ��ƿX"�>�5� S��۫�=�t�S���u2��$?ʋ��(��?5̃��pv���"=�䅿U�>��J�闙���I�~9Z<
Cﾎ�
�$2���§��#�>u�����>�{Z���侊!+�\��?)[��@��L)����?i*��!X�c�R���@�VC�r�/>�4��Ow侰]�<2�����=�F�?<�9pL������V����6��Ѿ:eg�S�������[�Ѧ˾$���޾��	���X�H:��y੾�yY�����>��Q��>$h*���+��1�>ZYm=b5g�`��=a�¾X#�ҥ>\��>�4�`_T�wǉ��D ���ڽ�6�ܤ=}�>)��>>e=+> ���<0>@2̾�g����Q>Jك=�� ��=��3�UB��'7*��D����7��:>`�'=�y����=�6���5���E�q���V���z1�=Xs��ɽS��<�`����?�ن���>o��:��21���1�}����=�L���.�~g/�ⱁ=����)�)��t>�r��q9=������ɿ=7��=/��J_ڽ�=�ތ�!���� 
�i���J^�R��=(�e.��drD����?��vֿ�����k?$Q	���3;����?����P�8��XW>�C۾
J��N����<�͟?�����᣾:�տ�+���&��Uپk����2־TmM=JYr�[���E=3{K�2af��俦������ٽ��>.$�=3X����I�
�R>�pĿhN��`N�?6��?��=�.�B�=�d�>y�>/�����=�9<��$>���`� =0�!��7>&�>q�O��O>Y�>>cE.�� 忹�<Z�-?<�R�ly=I0	>ԿY�˼�0�H�ۼ�E9�M_�=Oӽ���<3��>L� ��J>>i�>%��<q�%��$��B5;��;?H@���j������+�>�d�WB���+�=h��<z}�=��=%]>>�*��j2�v:9>�"}>O��=�4�TEq�TL��ޯB�[��B��=V-:<�6��>��9<���MG��R>��Y�j?ǿ��<�'�>�wӿ߾l�D��wվiZ|?�q>⊿���=,��>��ǽ�= �k>DF����T=�/����\<��Ŀ�1>ʄ����~�ul@��X�ʚ}��,	�X�>��^?8gP�<����`>G����5��'>�&q�e0޾��2=�K=x���|�=���<w=� ˽H��e�C�����,�;�7�x��(��=���Ӂ���"=���BZ�¼��h�=��(=Q!��g���A4{�E5�&��ȡ���I�s���B��=pys=��"���=�9�+����3�������ҽ�Y�<�K�>ڇ-=䗕�c����a�>�%���>?vP��W�>J^`���=N���f�=Ό=#�>9�>;��>uƾ<q`���
��=�̈=(8e>6M꽢�/����>���c"�=n���~.�=G9��h"�0�?�HZ>��=+,��I�>�4����Z@M�2սM���u}��N�=v�B��������!�=)�@>� =���?͜?��-=F��J�����=�oн|�\>�2
:�g�>Z�<<ΐ�=5��=�1��W`�=QC�(p>�Cq�Q�B���>���3ע>q�M�]�B��=mv�-��q�(�T�U�y>�3T�R��=�2��[�ؼ���=�<�=��ս�b��ʲ�{tۼ�C�T�b��5�ܶH=&�v��vC�����-�W+4<R�m=OU��Խ�－`��G4��b�E��=d�1���x=æB�J��/2=�?�Piu�"2�J�H�~|A�Lٷ=�xM���^=���p�K��~>�<?ꅂ�}�>�1?(��*���6=�v�©a�t�b?;�������:���l�y�9�jw�V@�\я�k��e��>���>|�����O���0>qB�>�"�=-9�;�������|m��X�����_K�q�/���>�R2=�E½a�K>�@�=l��=o�K�m�Q�>��?��O�9�N�嗃�d<�?D�=	����E���?Z�>��]>q��ų��Tfc>A\Z����=�[��d���*־&Cn�W�����.>ݼ~��c�3>��Պ�x��3�->3=J���U�@�i�W�ӛ�B9��� >�s���K�Gq�=�����:���o��I�����ѽ�j������Y�=�ւ���=�5��	�;P�˽��Ѽ!$��iҽ����=I򜽯T]=A>(29���ֺμp=�v���	��	�O�K�.��=�X�dY� �B=�'Z=��T���ҿR�ݼ�?�>?6Iȼˌ�?�&�f�����d�}�������>���>��8;���	������~��7��)�>�[0� I~<�>p�>?��>��'��� @BB�;ܷ��k�H�r����Qz���w�cpS=?<���Z�sɾ�	�Z�o �+�v�>/ٽIP�=����-�5� �y>�3ٿt��������˙�u;0?� f>��ƍ���4�> ;�=�]C�*Y>��9��
�=X	�"��=�}�<Up>R8��|h�r�>��&��9a���&��$"���G?�ry��^f��ּ�������`R��c��yX~�i�E�D�=��<=(�q=��;��������=%��`m<����<�)X�.";��@=p6Ӽf���8�4w%��3:7��NW<�'ʓ�$_޽A�s��ޔ=ٷ���8��.=�ؽ��J<��:�<�9�Rrj�+==�r�=fP�<�M���u>�<�9�J�>"3�=��ܿ���>��>� F��{�?'�=�m>y�U>��y?tb3�C;����>�M�?g��?���>�i����'>��뼗�>���?�������	>0W�W��>I�'>Ċ7>���>�������?��=vh��(~=J3B>��>��=���>�aؽk��f� >�-�f�3��=bs	�6��˼�#A{���8?�g�>n����Ք=�_�>�2�=h��=�;~��$��Tw*>�/n�[�����)�?>C� ���ƽqo���A���ľHr��.��ޙ>B@ �������3�l&����W�=b׾���7s �2�>��� ��=O[��ֻL�ِ�����=�TV;U|�=�����`�:���8བྷ�׽���=�'��kU�>y�=�
���*�����=�X���=�j�~���R�F��_-�]('�?��*j�<(DH��!O=��ܽ�6�<�X�����=���JgN=����"���=���帻D,>Q%��k�۾E�_�%x)���~?z*>jbܿ�_5>݆	?��һ��=�Z	>f�ɾL��=J����%޿�}���� �����ه��6��=�u��1��:�����a>�{����=cN>8���9J�Y�@�"��p4����=��=A#۽�t���qh=7�d�{�@=�y��=��b=�E$��*M���=�X���:�=" �Ϥ��jX����:�\z<o�޽��U�<v��1`���{=��=�����=�ٸ��k�;�x��ڌC���� )v: Cu�@4� �<�^>$i=�z|���;=���+�>�U�$������"��=�qb�\^���h�>m(�>�UY>1�����W��l'���=ED>sd�=�y>�,�=(0�~:=�	�8|>���\��>?xm�%��7��<[�!�m��=XJ�-��?ܽr��=nrH<�H��:��v}�<d)S�g|�;ß?��m?g����>{?W��Yi��Qg�=<��������S?�HA�0^@��g��^��;傾�^��2�|��]��G>m/? aQ?nq<W!@��a�>A�#?Be���Yy��a>G�^�����ؘ��Ӊ=���s�7�a?����񲽄Y�'�>s��"F��dY#=7��$�P���ƽ��<McJ��Za���
��c��,�:���>fa�=P��,O=�h�=�խ���:��=�Y�<�U�����"��=�@�=I�N>h�(�A�ͽ
�>�%�du��(�㽤�H۽A���F>�#>C@=2�P�uJ>�]��}^"�&�ؽ�A/<��`�@�R�x�[��>��;��Y�'+�<L�G�*�>=p�-�<��=-0��_�A=���=%|y�!�� �U�*�ؽ�M�yY=N��8g�<`���`�*��p�4���,��\^�i��s� >�ݵ��A ��>��/<�>>A��aF���.�:������+>������hhV��d2��)����-�ƈ��F��fv>R,	�f�4�A�{���\IH����>>32n��oG�X⚾E���k٢��Œ�j\�G�����1=����tG��qP�t���G�����ߘ���	����������n>Q���((��i���	Z>��Խ8V>lӞ:m��?@��=���`�վԀ�=��<~CA>�*�> ��kcT=�����e������d>ť��?2?���>�;�=8�=}P�>N����̼�����=w-��l>���>m�>R"޽��S��٩�=Z&;�6��M��=n�6�zٲ=��>�z�=B�<���LG �ʅٻxbu=�;��Rt̽�1�<�0�*s6>>O�w% >=�<�4=O̲=N�=,����=_�x�@B)�+�4=C9< `���[ӽ4r%��|�<`����7= )B��Z콼>�_t��	����>L=�G7=�!��O��=<;�#���)�=JXO>
�>�� �}�.?BSY=�P ��#>�9>�=N�9<�;�=	��<�����(=J�ؾ�>�<ž�T7=�J�x��=�#>|�A>:����i=�� <ad�׃ȾE�=��=�FU��G��t�>�R@?�˕�,�T?��j>1�v�� 7��� �Ca��}���?!�w�?���H�Af��p�=�/��a�;!8>�Ū>�?���=�<=����>��>�*�{��<�7�=/�ӽc��3H�~	�=�-������>Wx<��       �˾(       ���w�����>U� >���=._�>q�޼tN!�X��>H������>#H�����><:>q!���_>v��ڌ���p>�un=���<{O(��da�qW>HJ>HD�<|	���[�յ�r�P=�� �,��>�p����0�����9�h��jJ�C�]����(       '��>�=E���V>�i;�Z0>e�>�����پ2�]>Ut��`J>4>(ݽ%]l>���>v9�>s��>�E7��Ɏ���>%#������Z[��О>�l��e�>=��Ј3����CN�,�%����I+1?) >e T����ߞL>��-��s�0��