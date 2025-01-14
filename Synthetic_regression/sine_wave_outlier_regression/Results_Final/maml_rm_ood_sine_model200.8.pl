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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_rm_ood_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_rm_ood_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2326971693584qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2326971693104qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2326971693008qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2326971692336q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2326971693392q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2326971693200q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2326971692336qX   2326971693008qX   2326971693104qX   2326971693200qX   2326971693392qX   2326971693584qe.(       A�n���
�^�<H��I�b��?q����-�s4���ê�h�@�`sv�;z���W4��0?Eں��f�d&�!�=̈%�*��l��ٽjр?+��WB�=b�M�a�9�Ʉ�>��ӿ�N��U��S떾�W�>N;�Fӓ>s�T<�O=���F��@       ~�;#Ҿ�*�?�s�<�y��0��C�a�Σ���Z>���>���(9=��f>��>N|�d>�mR>i>R�=5b���g���۽Ox����>�O>C�=d쮻i�^=���/̹�1>�L�I�؃�=����I����2� >��=!y�==(D�=P��w?���ؿ�_�=�č��P>������8��|ܽ;�	�o;�?��~Y�����=�;��*�k�%~!><��=\?F�̿�I���?����ฉ>�E�%Ve>it�=/x�>*>���?W!�(�>m˾h�?���>����c��r߽����6#�=bn��[P���X��;����<s�=,U����/�=V��=oz۾N�콾�	�3�=��<l��n��� �?;�,6�$_=:��ܠ>�Y*���w�1���˽e�� ���V�$��ٽ\`��$��{ۼ��=2��<�� ��` � �ʼ8;���e���"����`�8����=##佐~j�]��X�<@�r;��x=[��.�=��>n1����Ƽר��3ؽ˴�\���X�=��=@&=`	^=����*'�=PϼnV�=3'��`B���f�=�����Ͻj��pѼ1���q>QK=��ǽॳ= ���-�`<h��:ӽ$~���~H�e����<�_Ž�K¼�a�=>��=�(�466���={�ͽ��4��`>����P��\S<5����c9�Z1������|Lܽ�����M��<��O��$�&���ʼ%�S��@���r��c�<��v=y�F�Խ�=4���m���E-?F|ؿq�>��`=�nj��
�I�[>��Q�a�R>[��>�����>�g����O�$1�|z4>Zj4>�Ŀ�^>I�%�~Ox����>���>���>�>lぽþ�H?�x"�!K?�C~>��ڽ	?��yZ0��~�?j+�>�-t>x~
=|�t�DEJ?f��=��_�n�U{C�Y��qXO=�l(=���~띾IY">��<>��E���o>5!�=N;�*Ӡ��^���;;��Ⱥ<;(7������=��=�G>X��=�&��\��3_E�M�w��z(?����;���P�ƄJ>
��<��>Pu� ���7��{�m?���F=M=���Ĝ��|�&�=�{�` �{��>�3[=��>(�=^1u=ۡ�;���Ұ���^w>�>���9 Q�.n>�g��B�w��ý`
j=큕���9�u�a=�R���>*F$������\��}ʽ���
�ؽ���0!�����?P��?P��C�>+�=]c�>�G�>��?>��>ꌓ>+#��1�>h��>6G��Ç>"��>�X�ţ�>��ܾ�?c<���x���?����A�=h@I���o>��N���[?舄���&?�����>b_
������>P�:���>��>	�=<sʽ�.=Q���Ga˽𠔽�{��S�z���O0��C;��
r�?i~�v�d=���7������%�m2^=H��#�mͽf��n{�Ch���>�ڼ/�"ԽT&C���d=�-�=�fD��|�Mc�b2սp�4�=�=�����.�2�=�z��mf���ɽ	���<%�I������X��m6�E<.;���!�=�)ֽ�=������t��q��� A�1����R'�A�} r��O����=���J��0�=�s��V3���������s=�\���Kʾ
9L�����ٽX=-�%�P�N���@w?ؚ�?�5�₄<A*�	�@��e>(��>�u�=N�9�;X�Z��=?�>��R��>�<�>�/<�KIC>�3��7��>R��>\�;��>��K�={=��y����@�l��0�<�dc�������ҽ�o�A5��cM��˫>��׾�7S>��^�� >b����_�>�ͩ��C����=� ����Ϳ�ɼ�o;֯�=A>�/нi���h>��Ľ3*��������=5�=<,�={u:���)��MM��>BJ��J?d�<������>�ی>vnc<^k�E�t>�|���Ⱦ����<�>�2�	�t>f٩�R�}�ܻ@����X� �7=3I��oG�-G�>�y>-׾��E��aa>��&>d��9�f>m{k>���8@>i�伣�X�)�<��4�J�>�t|=�=�;��=<Ձ���Ϣ�6*3��}�[㠾;�?� �=���Y�^��^�>��>�R>����Z���?=K@��E=��㿦>	U��5a�>u^��
>����l�E��a(>����:�l���J>�ܾFqB�`e�ƚW������b��:����T�w��=+�O>��>c�U=�	?��?{Ǝ���z>1��>��㾇:��6Ũ�0W8��p�=��J>����~�� ��?��k�����@���Gi�Z=B{t>W6�O��>�8�*��>8�>�����><=.>����)7�>@���R"c>+A�����=I���O �K�)���M=WŽ�X>wR�>Z'=>ؔ�>~Z��p����=���9L�b@1>1���5ػ>x�I��|ؽf��=�yj>S�D�ؽ�#ʼ����zy]=��=n>P<���:�<��=���[��<-���+�ͭʾO��d��=4�%��=������.���έB|=u53�XNd=^��P=�|Z3�Џ	�*1N�~�Y=+������a��=�-�7�ڽ���ؗT=W��O;s�7�ɽA��=��;c4���������:#�%��!$�p�I<������̵"�񨔾zO�-���\f�� @�7n�?>1ΐ�^8�^���������|�3%2���ؽ���;ol��+6���D�!\��h�O= g'��q��Lt�n�.��E�&��c�g�о;� C?��i���<5��~#�ሣ�iAJ�����ڠ�鱑�1o4�(࠿���9Y6`���V?�־��y��^�;�/�?wÿ��w�R^��xx�=s������>v<���U(�������mE��O?iH?5���9�����ނ*� bq=��l�����
 ��}�h����f�,�V-��$�]<U�+P����=�9��̀�G��=�|Z��ɛ�?�ɐ���>��پ`X,�g�?q?��`(���r��6�����f�"����[�`��Ԛ����<S�=�+U>Kl:�����lq�Á��ʽf�ٽ�Ɛ��e�=9>�Ћ�� >��X��B�� ��;�/�=ů!��;���#?����[��Vм��<<��V��T>\7=s�1��#��f��(�<t�x=�s�vƖ���*�g�=��U�I�½Q!��;�X�
���/������]�U�o"�9>�=����������<ԥ��D�e�C��(pN���
��b<WoA�~d��V7��χ��B�ǘ�UO+=������u�)��<�w�����o������Ex�񿏽�R�#U#��1��[t�!]H�qri�ە���Al�R�½f�Y�����%t&�t ��7�=����v6����݂ؽ�f��ʹ�=�`D<��Y�Π�=���=u>�(���21|��˞�Qw���T=!G󽢞�f׾=DE=�Z'��V�<<52���s=�2j�%A�!n���= �E�l�ӽ��ýXX�=B$$<Z���ec�=|X=� �Xn�:�T�=�տ�����ς?�޾D�_>��>����h+��}���Ͽ�D������s|��*˽�w���M��V����꾘rV�¸8�&Q�>t[��k����?��6��G?�I�9o��*�b<R��%�>j)U?H?QF?�r���|�������>>[�=Q��>2?�J>;�������־T��=g�k���&���K�"���|3 ��5w=&���0�j�u>Q��O?����1������	��"Q?�.=u���ݨ�h���%���l4>q}�<��4�&�5�d�N������>-F7�����{w��3+������^}�<�V=���<s���G9׽\>�,'��~�<'�]�d_y=�X>���<������&������q<�<��H����r�s�iA;�e-�NL"�ňh����g���@�6���ؽ`h�������=��ӽ�a�6��R���,/���ʳ���%<���Ԅ=f��[˽+,=�����뜽)����ż%��=���=���!�-=z�����=z4�<J
��`d���>�8=h	��i�ս%��=��v:ۈ	=5䷼=<�=���=�����U9��;���<Y�W=d�����<�ў����Ƕ��Ez��r�=I�X�[=埪�T�m˙=� �=������ͼWŭ=�JU�R3���R6���9�[������3��Ҩ�H�=j��y&9>�N=��=���<X����<��4���V���M�i0ؾdT���L�������=!�=� k��=�d��������<�=�^��sV#���ؾwE�����
�e�9>��w���v�4�V����~ ��f���ߖ��Lپ@��}.?��@�U"οY,����ž�%�?!�¾U
=����<��Sw޾M;>��>�$�]�f��' =�
��	+?3z[?>�˴�� �+uǾ+�	��u��o�q���=H��� ��;K�u=NW��K��4���\ ��s >?�U�&�em>� ��/���a>㉇�y�>�}��t+=A�;>�D�)� ?xn��2�z��^���x*�T�@���?�`=Ed�?��>R˼=x4ؾ�x�xmb>�ƽ��P� �c<�.>�>ߌ��(>Å��Ƚ��V=n�����=ׯ�=O{�=����N����=�	�< j<�מ=Ǚ=���=���=�=�=�c�d+�=#G��g�[۞=Q��v�нd�˽I������,
>٭-�H�A�����]`=�`=M�	�u�<��S�I?8c2?}�<0a�F/�=E�->��;>kzb�̱�	����>֫2�jrA���>��K���f���~�6�<@�>�h����Ƚ/Z����ý����}��Ӯ�.��<��b�Dg�>��?UJ>4V� ��>`���J\�Jb뽳���8@��U�=���ML�>�¡�HV��&�=�p�r"��;�<��>�&�=���>��J�D>=ǟ�>Hcľ/�����>\�?`��=Bt����Q>�GW�Y�o?׆�>���Ž��G�{<��>z���7��;ܾ ���✺��?d��=�3>.�̎,�&$���O½<���y�l����?/�ɾ4=
��>��ݽ��t���g��nE��ݭ�+���+Ժ���=�El8�
�A���L����<���s3��	#?��`?���e�>@,���c�>�	�ڃ�7*z��8;� ;輩��>+�?53?�Kt>g���`�=�>���>3�	�9D�=�)?�x�<	���Rr!�fU(=2$�w�^>�ق=5����U<��C>��4>�]�P�>�dټ�u����=���>(�;�D��N�v��[>v��֫4>@AO=(�<1��Q|��[q���U�����=:�=<�ZW��U����=�?�<|;8>Ϩ>�C�<j�z>74��k�AeE=a��/,>���=>�����EM�<ͩ	�_3���D*��$�)OоGp��*9?�p�����e���v����qL?����$h����b�����ʾe�>ix��?�8ik>�����d����>�!?#�%���D��t�
�d>+���@@��q-���U���b>����h!�;�� �<A��F��=e;#�����0� =C
 � �<�� ��[����=��.+�=pֵ=��<|�=��F�h��#�ܽ��?=����c����ދ�E%̽u o=�\��(X���==��)���=�4�s�=rm��ZL$�Vg`�G���N�����I�J���=�W��EjQ��TY=
�e��*:����<��������<7�o�F�)<�aF����X��=�_����8˼��A�7��<BrĽ�+����E��jZ�=���o��U�ڽ���c������鉓�q�=9��)����n��Ј=� �+ͽw>;@s=UT�=u�ŧ�I�!=�%�<��=��L�=�2��ee�<��	�Iȼ9n����ɽD9=Y�=_�Ⱥ��K��Z^;Vj߽��=��7���=�����N�=�Bz��ۍ�=�6l���ص=���<�- ?����Ѿ��ѿ�#�<d�@�!�P�0ϯ<m!_>�� ��,�=�;>�L�=���=��>6q�=S�9?��>��>O�x�.aP�	�F?�G������>��Ž���>�Գ>d���Q6>\)����--
<�W>����K�B>�_ؿf��>�?=(       X� ���X>��>��J>)2��^:<�վR��=$a����#�(�����
���������0Ŀ�w���[��io?z�o�ݫѿY����=V? ����k>>@��(�=2ߪ�#��>�&�>�/�>�����>m�~�-��=��?6�z�KF�=�������       >��(       �L>K�:?�X8��>�㚼z� ?�¤>*��=��?��>�S\=xTT>��=@n�>�^>����m�<w҃=<nu?����&>�;6��I<�)&���Ǿ>1����=�����dJ?O��<G����)?J����>�:�=!}Q?�b9��qD�gw=Q �(       ���c��?�>="���������W�>��C<�@���� ��(NB?��$�I�����H?p�����	����<3����*?a.�4�
�����s�(��ŝ�漾O��0�����2;|�$�D?���>z�н'R?��]=
�5;�~���������+?